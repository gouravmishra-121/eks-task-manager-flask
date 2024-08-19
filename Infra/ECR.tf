 resource "aws_ecr_repository" "my_flask_app_repo" {
    name = "my-flask-app"

   image_scanning_configuration {
     scan_on_push = true
   }

   image_tag_mutability = "MUTABLE"

   tags = {
     Name = "my-flask-app-repo"
   }
 }




 output "ecr_repository_url" {
   value = aws_ecr_repository.my_flask_app_repo.repository_url
 }
