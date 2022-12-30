import { Module } from '@nestjs/common';

import { AppController } from './app.controller';
import { AppService } from './app.service';

@Module({
  imports: [],
  controllers: [AppController],
  providers: [
    {
      provide: AppService,
      useFactory() {
        return new AppService(process.env.APIURL ?? 'http://localhost:3333/api/hello');
      },
    },
  ],
})
export class AppModule {}
