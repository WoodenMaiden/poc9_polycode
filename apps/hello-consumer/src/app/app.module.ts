import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { RedisModule } from '@liaoliaots/nestjs-redis';

import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PassportModule } from '@nestjs/passport';

@Module({
  imports: [
    JwtModule.register({ secret: process.env.JWTSECRET ?? 'secret' }),
    PassportModule,
    RedisModule.forRoot({
      config: {
        host: process.env.REDIS_HOST ?? 'localhost',
        port: 80,
        password: process.env.REDIS_PASSWORD ?? 'password',
      },
    }),
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
