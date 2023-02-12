import { Express, Request, Response, json } from 'express'
import { models } from '../db/db'
import { protect } from '../utils/authExtraction'
import { formidable } from 'formidable'
import fs from 'fs'
import path from 'path'
import mv from 'mv'

export function whatever(app: Express) {

    app.patch('/storage/sync/', protect, (req: Request, res: Response, next) => {
        /* 
            #swagger.security = [{
                "bearerAuth": []
            }] 
        */
        const form = formidable({ multiples: false })
        form.parse(req, (err, fields, files) => {
            if (err) {
                return next(err)
            }
            const desiredFile = files.db
            if (desiredFile == undefined) {
                return next(Error("No db file sent"))
            }

            mv(desiredFile.filepath, path.join(process.env.DB_SAVE_LOCATION!, res.locals.id), (err) => {
                if (err) {
                    return next(err)
                }
                res.status(200).end();
            })
        })

    })

    app.get('/storage/db', protect, (req: Request, res: Response, next) => {
        /* 
            #swagger.security = [{
                "bearerAuth": []
            }] 
        */
        res.status(200).sendFile(path.join(process.env.DB_SAVE_LOCATION as string, res.locals.id))
    })

}