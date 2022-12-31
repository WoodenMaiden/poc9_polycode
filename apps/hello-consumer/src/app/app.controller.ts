import { Controller, Get, Post, Logger, UseGuards, Body, Headers } from '@nestjs/common';
import { AppService } from './app.service';
import Creds from './Creds';
import { JwtAuthGuard } from './jwtguard.guard';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get("/hello")
  @UseGuards(JwtAuthGuard)
  async getData(@Headers("Authorization") authorization: string): Promise<{ message: string }> {
    const msg = await this.appService.getData(authorization);
    Logger.log(msg);
    return { message: msg };
  }

  @Post("/login")
  async login(@Body() credentials: Creds) {
    return this.appService.login(credentials);
  }

  @Post("/signup")
  async signup(@Body() credentials: Creds) {
    return this.appService.signup(credentials);
  }
}
