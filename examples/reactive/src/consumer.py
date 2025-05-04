import asyncio
import os

import aiokafka


async def main(
    bootstrap_servers: str = os.getenv("KAFKA_BOOTSTRAP_SERVERS", "localhost:29094"),
):
    consumer = aiokafka.AIOKafkaConsumer(
        "my_topic",
        bootstrap_servers=bootstrap_servers,
    )
    await consumer.start()
    try:
        await consumer.seek_to_beginning()
        async for msg in consumer:
            print(
                "{}:{:d}:{:d}: key={} value={} timestamp_ms={}".format(
                    msg.topic,
                    msg.partition,
                    msg.offset,
                    msg.key,
                    msg.value,
                    msg.timestamp,
                )
            )
    finally:
        await consumer.stop()


if __name__ == "__main__":
    asyncio.run(main())
