import { Injectable } from '@nestjs/common';
import { faker } from '@faker-js/faker';
@Injectable()
export class AppService {
  generateHello(): string {
    return `Hello from ${faker.internet.userName()}!` ;
  }
}
