// Declarative pipelines must be enclosed with a "pipeline" directive.
pipeline {
    agent {
        node {
        
        label 'slave'
        
    
        }


    }
    environment {
	region = "us-east-1"
        docker_repo_uri = "306272608230.dkr.ecr.us-east-2.amazonaws.com/rahul"
	task_def_arn = "arn:aws:ecs:us-east-2:306272608230:task-definition/first-run-task-definition"
        cluster = "jenkins-cluster"
        exec_role_arn = "arn:aws:iam::306272608230:role/FNB-ECS-SSH"
    }
    
    // Here you can define one or more stages for your pipeline.
    // Each stage can execute one or more steps.
   
	stages {
		stage('Build') {
    steps {
        // Get SHA1 of current commit
        script {
            commit_id = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
        }
        // Build the Docker image
        sh "docker build -t ${docker_repo_uri}:${commit_id} ."
        // Get Docker login credentials for ECR
        sh "aws ecr get-login --no-include-email --region ${region} | sh"
        // Push Docker image
        sh "docker push ${docker_repo_uri}:${commit_id}"
        // Clean up
        sh "docker rmi -f ${docker_repo_uri}:${commit_id}"
    }
}
		
		stage('Deploy') {
    steps {
        // Override image field in taskdef file
        sh "sed -i 's|{{image}}|${docker_repo_uri}:${commit_id}|' taskdef.json"
        // Create a new task definition revision
        sh "aws ecs register-task-definition --execution-role-arn ${exec_role_arn} --cli-input-json file://taskdef.json --region ${region}"
        // Update service on Fargate
        sh "aws ecs update-service --cluster ${cluster} --service sample-app-service --task-definition ${task_def_arn} --region ${region}"
    }
}
		
      
    }
}
