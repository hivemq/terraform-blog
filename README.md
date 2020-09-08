<p align="center">
  <img src="https://www.hivemq.com/img/svg/hivemq-logo-vert.svg" width="150" alt="HiveMQ">
</p>

## Automate your HiveMQ installation with Concourse Ci
 
This is the companion repository for the blog post:  
https://www.hivemq.com/blog/setup-hivemq-with-concourse-pipeline/  
 It contains the infrastructure code to install HiveMQ with Concourse CI and Terraform on AWS.  

---

#### How to use

- Install Concourse CI locally
  - Download and run the Concourse CI docker-compose file  
  `wget https://concourse-ci.org/docker-compose.yml`  
  `docker-compose up -d`
  - Install Concourse CLI tool _fly_. [Instructions are here.](https://concourse-ci.org/fly.html)
- Clone this repository
- Add necessary parameters to the _"pipeline-vars.yml"_ file
- Use the associated makefile:  
  `make login`  
  `make create-cluster`
  
---  

HiveMQ is a fully compatible MQTT 3.1.1 and 5.0 broker. Find more information on HiveMQ here:
- [HiveMQ documentation](https://www.hivemq.com/docs/hivemq/)
- [HiveMQ community forum](https://community.hivemq.com/)


Read and see more from the HiveMQ team here:
- [HiveMQ blog posts](https://www.hivemq.com/blog/)
- [HiveMQ Youtube channel](https://www.youtube.com/channel/UCiquDynjDdcSDuhdoE4vy1w)
- [MQTT Essentials](https://www.hivemq.com/mqtt-essentials/) and  [MQTT 5 Essentials](https://www.hivemq.com/mqtt-5/) 
---

License: [Apache 2.0 license](LICENSE) 
