import {
  Injectable,
  UnauthorizedException,
  ConflictException,
  Logger,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import axios from 'axios';
import { InjectRedis, DEFAULT_REDIS_NAMESPACE } from '@liaoliaots/nestjs-redis';
import { Redis } from 'ioredis';

import Creds from './Creds';

@Injectable()
export class AppService {
  constructor(
    private readonly JWTService: JwtService,
    @InjectRedis(DEFAULT_REDIS_NAMESPACE) private readonly redis: Redis
  ) {}

  async getData(authorization: string): Promise<string> {
    Logger.log(authorization);
    const res = await axios.get(
      process.env.APIURL ?? 'http://localhost:3333/api/hello',
      {
        headers: {
          Authorization: authorization,
        },
        timeout: 3000,
      }
    );
    return res.data;
  }

  async login(credentials: Creds) {
    const userpwd = await this.redis.get(credentials.username);
    if (userpwd && userpwd === credentials.password) {
      const payload = { username: credentials.username };
      return {
        access_token: this.JWTService.sign(payload),
      };
    } else throw new UnauthorizedException();
  }

  async signup(credentials: Creds) {
    try {
      const exists = await this.redis.get(credentials.username);
      if (exists) throw 'User already exists';
      
      await this.redis.set(credentials.username, credentials.password);
      
      const payload = { username: credentials.username };
      return {
        access_token: this.JWTService.sign(payload),
      };
    } catch (e) {
      throw new ConflictException(e);
    }
  }
}
