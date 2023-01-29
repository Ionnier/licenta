import { google } from 'googleapis'
import * as express from 'express';
import * as path from 'path';
import * as dotenv from 'dotenv';

dotenv.config()
const app = express()


const secrets_name = "secret_key.json"
const PATH_TO_JSON = path.join(__dirname, secrets_name)
const SPREADHSEET_ID = process.env.SHEET_ID
const port = process.env.PORT || 3000

const DATA_SHEET_NAME = "Sheet1"

const activity_types = [
    "Well-Being",
    "Relax",
    "Sport",
    "Study",
    "Work",
]


async function main() {
    const auth = new google.auth.GoogleAuth({
        keyFile: PATH_TO_JSON,
        // Scopes can be specified either as an array or as a single, space-delimited string.
        scopes: ['https://www.googleapis.com/auth/spreadsheets']
    });

    const sheets = google.sheets(
        { version: 'v4', auth }
    )

    async function insertData(
        date: any,
        category: any,
        name: any,
        sessionTime: any,
        completionTime: any,
        remainingTime: any,
        timeSpentInSession: any | undefined,
    ) {
        if (activity_types.indexOf(category) == -1) {
            return
        }
        const response = await sheets.spreadsheets.values.append({
            spreadsheetId: SPREADHSEET_ID,
            range: `${DATA_SHEET_NAME}!A:A`,
            valueInputOption: "RAW",
            requestBody: {
                values: [
                    [
                        date,
                        category, name, sessionTime,
                        completionTime, remainingTime, timeSpentInSession
                    ]
                ]
            }
        })

    }

    // await insertData(
    //     Date.now(),
    //     "Sport",
    //     "Alergat",
    //     60,
    //     Number.MAX_VALUE,
    //     Number.MAX_VALUE,
    //     60
    // )

    // const response = await sheets.spreadsheets.values.get({
    //     spreadsheetId: SPREADHSEET_ID,
    //     range: `${DATA_SHEET_NAME}!A:A`
    // })

    // const data = response.data.values
    // console.log(data)

    app.post("/api/insert/", async (req, res) => {
        console.log(req.query)
        const asd = req.query

        const timestamp = asd.timestamp
        const category = asd.category
        const name = asd.name
        const sessionTime = asd.sessionTime
        let eta_compl: any = asd.completionTime
        let eta_rem: any = asd.remainingTime
        const timeSpent = asd.timeSpent

        if (
            timestamp == undefined ||
            category == undefined ||
            name == undefined ||
            sessionTime == undefined
        ) {
            return res.status(400).end()
        }

        if (eta_compl == undefined) {
            eta_compl = 999999
        }

        if (eta_rem == undefined) {
            eta_rem = 999999
        }

        await insertData(
            timestamp,
            category,
            name,
            sessionTime,
            eta_compl,
            eta_rem,
            sessionTime
        )

        res.status(200).end()
    })

    app.post("/feedback", (req, res) => {
        res.end()
    })

    app.listen(port, () => {
        console.log(`App listening on ${port}`)
    })
}

main()

