import logging
import apache_beam as beam
from apache_beam.io.kafka import ReadFromKafka
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.io.kafka import default_io_expansion_service

def run_beam_pipeline():
    logging.getLogger().setLevel(logging.INFO)

    consumer_config = {
        'bootstrap.servers': 'cluster-0-kafka-bootstrap.strimzi.svc.cluster.local:9092',
        'group.id': 'beamgrouptest',
        'auto.offset.reset': 'earliest',
    }

    topic = 'locations'

    flink_options = PipelineOptions([
        "--runner=FlinkRunner",
        "--flink_master=flink-jobmanager:8081",
        "--artifacts_dir=/tmp/beam-artifact-staging",
        "--environment_type=EXTERNAL",
        "--environment_config=localhost:50000",
        "--flink_submit_uber_jar",
    ])

    with beam.Pipeline(options=flink_options) as pipeline:
        (
            pipeline
            | "Read from Kafka" >> ReadFromKafka(
                consumer_config=consumer_config,
                topics=[topic],
                with_metadata=False,
                expansion_service=default_io_expansion_service(
                    append_args=[
                        '--defaultEnvironmentType=PROCESS',
                        "--defaultEnvironmentConfig={\"command\": \"/opt/apache/beam/boot\"}",
                    ]
                )
            )
            | "Print messages" >> beam.Map(print)
        )

    logging.info("Pipeline execution completed.")

if __name__ == '__main__':
    run_beam_pipeline()
