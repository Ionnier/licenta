import { Express, Request, Response, json, NextFunction } from 'express'
import { models } from '../db/db'
import { protect } from '../utils/authExtraction'
import { formidable } from 'formidable'
import fs from 'fs'
import path from 'path'
import mv from 'mv'
import amqplib from 'amqplib'
import { logger } from '../utils/logger'
import sqlite3 from 'sqlite3'
import { open } from 'sqlite'

export function whatever(app: Express) {

    app.patch('/storage/sync/', protect, (req: Request, res: Response, next) => {
        /* 
            #swagger.security = [{
                "bearerAuth": []
            }] 
        */
        logger.info(`Start /storage/sync/`)
        const form = formidable({ multiples: false })
        form.parse(req, (err, fields, files) => {
            if (err) {
                return next(err)
            }
            const desiredFile = files.db
            if (desiredFile == undefined) {
                logger.info(`No file sent`)
                return next(Error("No db file sent"))
            }
            console.log(res.locals.id)
            logger.info(`Start move`)

            mv(desiredFile.filepath, path.join(process.env.DB_SAVE_LOCATION!, res.locals.id), (err) => {
                if (err) {
                    return next(err)
                }
                res.status(200).end();
                produce(res.locals.id)
            })
        })

    })

    app.get('/storage/icalself', protect, (req: Request, res: Response, next) => {
        logger.info(`Start iCalSelf`)
        res.status(200).json({ data: `/storage/ical/${res.locals.id}/` })
    })

    app.get('/storage/ical/:id/', async (req: Request, res: Response, next: NextFunction) => {
        logger.info(`Start iCal for id`)
        try {
            const db = await open({
                filename: path.join(process.env.DB_SAVE_LOCATION as string, req.params.id),
                driver: sqlite3.Database
            })

            const ical = require('ical-generator');
            const calendar = ical({ name: `Ical` });
            const rows = await db.all("SELECT * FROM plans")
            interface RootObject {
                localId: number;
                remoteId?: any;
                parentId?: any;
                name: string;
                startsAt: number;
                endsAt: number;
                createdAt: number;
                modifiedAt: number;
                completed: number;
            }
            for (let row of rows) {
                let ns: RootObject = row
                calendar.createEvent({
                    start: new Date(ns.startsAt),
                    end: new Date(ns.endsAt),
                    summary: ns.name,
                    description: ns.name,
                });
            }
            db.close();
            return res.status(200).contentType("text/calendar").end(calendar.toString());
        } catch (e) {
            console.log(e)
            return next(e)
        }
    })

    app.get('/storage/db/', protect, (req: Request, res: Response, next) => {
        /* 
            #swagger.security = [{
                "bearerAuth": []
            }] 
        */
        logger.info(`Start get Db`)    
        res.status(200).sendFile(path.join(process.env.DB_SAVE_LOCATION as string, res.locals.id))
    })

    app.get('/storage/getdb/:id/', (req: Request, res: Response, next) => {
        logger.info(`Start get Db for id`)    
        res.status(200).sendFile(path.join(process.env.DB_SAVE_LOCATION as string, req.params.id))
    })

}

const amqp_url = process.env.CLOUDAMQP_URL || 'amqp://localhost:5672';

async function produce(id: String) {
    logger.info(`${id} DATABASE_UPDATE`)
    var conn = await amqplib.connect(amqp_url);
    var ch = await conn.createChannel()
    var exch = 'test_exchange';
    var q = 'test_queue';
    var rkey = '';
    var msg = `${id} DATABASE_UPDATE`;
    await ch.assertExchange(exch, 'fanout', { durable: true }).catch(console.error);
    await ch.assertQueue(q, { durable: true, autoDelete: true, exclusive: false });
    await ch.bindQueue(q, exch, rkey);
    await ch.publish(exch, rkey, Buffer.from(msg));
    setTimeout(function () {
        ch.close();
        conn.close();
    }, 500);
}