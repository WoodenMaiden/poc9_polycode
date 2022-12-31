import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';

import { AppController } from './app.controller';
import { AppService } from './app.service';

@Module({
  imports: [
    PassportModule,
    JwtModule.register({ secret: process.env.JWTSECRET ?? 'secret' }),
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
