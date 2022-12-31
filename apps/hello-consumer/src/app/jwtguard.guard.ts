
import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { Request } from 'express';
import { JwtService } from '@nestjs/jwt';


@Injectable()
export class JwtAuthGuard implements CanActivate {
    constructor(private readonly JWTService: JwtService) {}

    canActivate(context: ExecutionContext): boolean | Promise<boolean> {
        const request: Request = context.switchToHttp().getRequest();
        try {
            this.JWTService.verify(request.headers.authorization.split(" ")[1]);
            return request.headers.authorization? true : false;
        } catch (error) {
            return false;
        }
    }
}