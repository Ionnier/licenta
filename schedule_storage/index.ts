import { config } from 'dotenv'
config()
import { initDatabase } from './db/db'
import { logger } from './utils/logger'
import express from 'express'
import { whatever } from './controllers/syncController'

const swaggerUi = require('swagger-ui-express')
const swaggerFile = require('./swagger_output.json')


// if (!process.env.DATABASE_URL) {
//     logger.error("No database URL.")
//     process.exit(1)
// }

initDatabase()
const app = express();

whatever(app)

app.use('/docs', swaggerUi.serve, swaggerUi.setup(swaggerFile))


app.use((error, req: express.Request, res: express.Response, next: express.NextFunction) => {
    console.log(error)
    if (error instanceof Error) {
        return res.status(418).json({
            message: error.message,
            error: error.stack,
        })
    }
})

process.on('uncaughtException', (err) => {
    logger.info('whoops! There was an uncaught error', err);
    console.log(err)
    process.exit(1);
});

app.listen(3000, '0.0.0.0', () => {
    logger.info("Server started")
})



