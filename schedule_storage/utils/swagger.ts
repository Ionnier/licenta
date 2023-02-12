import fs from 'fs';
import path from 'path'

const swaggerAutogen = require('swagger-autogen')()

const endpointsFiles: string[] = [
]

function appendDirectory(dirPath: string, recursive: boolean) {
    try {
        const files = fs.readdirSync(dirPath, {
            withFileTypes: true
        })
        for (let file of files) {
            if (file.isDirectory() && recursive) {
                appendDirectory(path.join(dirPath, file.name), true)
                continue;
            }
            if (file.isFile()) {
                endpointsFiles.push(path.join(dirPath, file.name))
            }
        }
    } catch (e) {
        console.log(e)
    }
}

appendDirectory(path.join(__dirname, "..", "controllers"), false)

console.log(endpointsFiles)
const outputFile = path.join(__dirname, "..", "swagger_output.json")

swaggerAutogen(outputFile, endpointsFiles)