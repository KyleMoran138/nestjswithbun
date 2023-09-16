import { Injectable, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class AppService extends PrismaClient implements OnModuleDestroy {
  private interval: NodeJS.Timeout;

  constructor() {
    super();

    console.log(`Database URL: ${process.env.DATABASE_URL}`);

    // Create a timeout where every 30 seconds we will refresh the database connection
    this.interval = setInterval(async () => {
      const user = await this.user.create({
        data: {
          name: Math.random().toString(36).substring(7),
        },
      });
      console.log('Created user', user);
    }, 10000);
  }

  getHello(): string {
    return 'Hello World!';
  }

  async onModuleDestroy() {
    // Clear the timeout
    clearInterval(this.interval);
    await this.$disconnect();
  }
}
