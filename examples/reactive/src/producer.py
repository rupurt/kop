import asyncio

import aiokafka


async def main():
    producer = aiokafka.AIOKafkaProducer(bootstrap_servers="localhost:29094")
    await producer.start()
    try:
        await producer.send_and_wait("my_topic", b"Super message")
    finally:
        await producer.stop()


if __name__ == "__main__":
    asyncio.run(main())
