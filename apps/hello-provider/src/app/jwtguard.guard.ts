
import { Injectable, CanActivate, ExecutionContext, Logger } from '@nestjs/common';
import { Request } from 'express';
import { JwtService } from '@nestjs/jwt';


@Injectable()
export class JwtAuthGuard implements CanActivate {
    constructor(private readonly JWTService: JwtService) {}

    canActivate(context: ExecutionContext): boolean | Promise<boolean> {
        const request: Request = context.switchToHttp().getRequest();
        Logger.log(request.headers.authorization);
        try {
            this.JWTService.verify(request.headers.authorization.split(" ")[1]);
            Logger.log("JWT verified");
            return request.headers.authorization? true : false;
        } catch (error) {
            return false;
        }
    }
}