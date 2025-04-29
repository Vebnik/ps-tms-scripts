NAME ps-tms

FROM openjdk:21-jdk

COPY . "/home/singula/Work/pbf-work/pstms"

ENTRYPOINT ["./mvn/bin/mvn","-DfinalVersion=4.0.3","-DskipTests=true","clean","-T","4","install"]
