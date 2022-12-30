import { Controller, Get, Logger } from '@nestjs/common';

import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get("/hello")
  async getData(): Promise<{ message: string }> {
    const msg = await this.appService.getData();
    Logger.log(msg);
    return { message: msg };
  }
}
