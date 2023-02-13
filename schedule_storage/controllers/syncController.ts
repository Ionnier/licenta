import { Express, Request, Response, json } from 'express'
import { models } from '../db/db'
import { protect } from '../utils/authExtraction'
import { formidable } from 'formidable'
import fs from 'fs'
import path from 'path'
import mv from 'mv'
import amqplib from 'amqplib'
import { logger } from '../utils/logger'

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
        produce(res.locals.id)
    })

    app.get('/storage/getdb/:id/', (req: Request, res: Response, next) => {
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
    var rkey = 'test_route';
    var msg = `${id} DATABASE_UPDATE`;
    await ch.assertExchange(exch, 'direct', { durable: true }).catch(console.error);
    await ch.assertQueue(q, { durable: true });
    await ch.bindQueue(q, exch, rkey);
    await ch.publish(exch, rkey, Buffer.from(msg));
    setTimeout(function () {
        ch.close();
        conn.close();
    }, 500);
}
produce("asd");