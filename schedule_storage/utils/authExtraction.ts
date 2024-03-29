import { Request, Response, NextFunction } from "express";
import { verify } from 'jsonwebtoken'

export function extractId(request: Request): string | null {
    if (!request.headers.authorization || !request.headers.authorization.startsWith("Bearer")) {
        console.log("Authorization null")
        return null
    }
    const token = request.headers.authorization.split(' ')[1];
    const data = verify(token, process.env.JWT_SECRET_KEY)
    return data.id
}

export function protect(request: Request, response: Response, next: NextFunction) {
    const id = extractId(request)
    if (id == null) {
        return next(Error("Not authentificated"))
    }
    console.log(id)
    response.locals.id = id
    next();
}