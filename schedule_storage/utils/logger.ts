import winston from 'winston'

const myFormat = winston.format.printf(({ level, message, label, timestamp }) => {
    return `${timestamp} [${label || ""}] ${level}: ${message}`;
});

export const logger = winston.createLogger({
    level: 'silly',
    format: winston.format.combine(
        winston.format.colorize(),
        winston.format.timestamp(),
        myFormat,
    ),
    transports: [
        new winston.transports.Console(),
    ],
})