from flask import Flask, request
import dotenv
import os
import logging
import requests
import sqlite3

dotenv.load_dotenv()
STORAGE_DOMAIN_URL = os.getenv("STORAGE_DOMAIN")

if STORAGE_DOMAIN_URL is None:
    logging.critical("No storage domain link")
    exit(1)


app = Flask(__name__)


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
                cursor.close()
                return rows
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


app.run('0.0.0.0', os.getenv("PORT") or 3000, os.getenv("DEBUG") is not None)
