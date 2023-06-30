from flask import Flask, request
import dotenv
import os
import logging
import requests
import sqlite3
import json
import time
from datetime import datetime
import pytz  # pip install pytz
import openai

openai.api_key = "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"

dotenv.load_dotenv()
STORAGE_DOMAIN_URL = os.getenv("STORAGE_DOMAIN")

if STORAGE_DOMAIN_URL is None:
    logging.critical("No storage domain link")
    exit(1)


app = Flask(__name__)


class Task:
    def __init__(self, dictionary):
        self.name = dictionary[3]
        self.localId = dictionary[0]
        self.description = dictionary[4]
        self.total_time_estimated = dictionary[5]
        self.remaining_time_estimated = dictionary[6]
        self.preffered_session_time = dictionary[7]
        self.priority = dictionary[8]
        self.completed = dictionary[9]
        self.createdAt = dictionary[11]
        self.lastCompletedAt = dictionary[12]

    def toJSON(self):
        return json.dumps(self, default=lambda o: o.__dict__,
                          sort_keys=True, indent=4)

    def toDict(self):
        return {
            "localId": self.localId,
            "name": self.name,
            "description": self.description,
            "total_time_estimated": self.total_time_estimated,
            "remaining_time_estimated": self.remaining_time_estimated,
            "preffered_session_time": self.preffered_session_time,
            "priority": self.priority,
            "completed": self.completed,
            "createdAt": self.createdAt,
            "lastCompletedAt": self.lastCompletedAt,
        }


class Plan:
    def __init__(self, dictionary):
        self.taskId = dictionary[2]
        self.localId = dictionary[0]
        self.name = dictionary[3]
        self.startsAt = dictionary[4]
        self.endsAt = dictionary[5]
        self.createdAt = dictionary[6]
        self.completed = dictionary[8]

    def toDict(self):
        return {
            "localId": self.localId,
            "taskId": self.taskId,
            "name": self.name,
            "startsAt": self.startsAt,
            "endsAt": self.endsAt,
            "completed": self.completed,
            "createdAt": self.createdAt,
        }


@app.route("/suggest/", methods=["GET"])
def suggest():
    try:
        authorization = request.headers["Authorization"]
        if not authorization.startswith("Bearer "):
            raise KeyError("No Bearer token")
        tmp = open("database.db", "w+b")
        try:
            if getDb(tmp, authorization.split(" ")[1]) is False:
                return {
                    "message": "An error occured",
                }
            with sqlite3.connect(tmp.name) as connection:
                cursor = connection.cursor()
                rows = cursor.execute(
                    "SELECT * FROM tasks"
                ).fetchall()
                plans = cursor.execute(
                    "SELECT * FROM plans"
                ).fetchall()
                cursor.close()
                print(rows, plans)
                tasks = [Task(x) for x in rows]
                plans = [Plan(x) for x in plans]
                currentTimestamp = int(round(time.time() * 1000))

                asd = datetime.now(pytz.timezone(
                    "Europe/Bucharest")).replace(hour=23, minute=59, second=59, microsecond=0)
                midnightTimestamp = int(asd.timestamp()) * 1000

                plans = list(
                    filter(lambda x: (x.endsAt >= currentTimestamp and x.startsAt <= midnightTimestamp), plans))
                plans = sorted(
                    plans,
                    key=lambda x: (x.endsAt)
                )
                lastTimestamp = None
                if (len(plans) == 0):
                    lastTimestamp = currentTimestamp
                else:
                    lastTimestamp = plans[-1].endsAt

                timeLeft = midnightTimestamp - lastTimestamp

                tasks = list(
                    filter(lambda x: (x.preffered_session_time <= timeLeft), tasks))
                tasks = sorted(
                    tasks,
                    key=lambda x: (x.priority),
                    reverse=True
                )

                if (len(tasks) == 0):
                    return []

                content = "Avand task-urile cu: "
                for i in range(min(len(tasks), 5)):
                    content += f"{tasks[i].name} durata preferata {tasks[i].preffered_session_time / 1000 / 60} minute, prioritate {tasks[i].priority}, "
                content += f"si {timeLeft / 1000 / 60} minute disponibiel. Prioritizeaza"

                # create a chat completion
                chat_completion = openai.ChatCompletion.create(
                    model="gpt-3.5-turbo", messages=[{"role": "user", "content": content}])

                # print the chat completion
                return chat_completion.choices[0].message.content
        finally:
            tmp.close()
            os.unlink(tmp.name)
    except KeyError as e:
        return {
            "message": "Authorization not found",
            "error": str(e)
        }


def getDb(file, token):
    try:
        with requests.get(
            f"{STORAGE_DOMAIN_URL}/storage/db",
            stream=True,
            headers={
                "Authorization": f"Bearer {token}"
            }
        ) as r:
            if (r.status_code != 200):
                print(str(r.content))
                return False
            file.write(r.content)
            return True
    except Exception as e:
        print(e)
        return False


if __name__ == "__main__":
    app.run('0.0.0.0', os.getenv("PORT") or 3000,
            os.getenv("DEBUG") is not None)
