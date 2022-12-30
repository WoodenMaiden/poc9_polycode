import { Injectable } from '@nestjs/common';
import axios from 'axios';

@Injectable()
export class AppService {
  constructor(private readonly url: string) {}

  async getData(): Promise<string> {
    const res = await axios.get(this.url);
    return res.data;
  }
}
