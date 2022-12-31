import { Controller, Get, UseGuards } from '@nestjs/common';

import { JwtAuthGuard } from './jwtguard.guard';
import { AppService } from './app.service';

@Controller("/hello")
export class AppController {
  constructor(private readonly appService: AppService) {}

  @UseGuards(JwtAuthGuard)
  @Get()
  getData(): string {
    return this.appService.generateHello();
  }
}
