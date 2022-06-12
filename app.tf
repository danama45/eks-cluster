resource "kubernetes_ingress_v1" "app" {
    
  metadata {
    name      = "owncloud-lb"
    namespace = "fargate-node"
    annotations = {
      "kubernetes.io/ingress.class"           = "alb"
      "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
    }
    labels = {
        "app" = "owncloud"
    }
  }

  spec {
      default_backend {
        service{
          name = "owncloud-service"
          port{
            number = 80
        }
        }
      }
    rule {
      http {
        path {
          backend {
            service{
              name = "owncloud-service"
              port {
                number = 80
              } 
            }
          }
          path = "/"
        }
      }
    }
  

  #depends_on = [kubernetes_service.app]
}
}
  
resource "kubernetes_deployment" "app" {
  metadata {
    name      = "owncloud-server"
    namespace = "fargate-node"
    labels    = {
      app = "owncloud"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "owncloud"
      }
    }

    template {
      metadata {
        labels = {
          app = "owncloud"
        }
      }

      spec {
        container {
          image = "owncloud"
          name  = "owncloud-server"

          port {
            container_port = 80
          }
        }
      }
    }
  }


}
resource "kubernetes_service" "app" {
  metadata {
    name      = "owncloud-service"
    namespace = "fargate-node"
  }
  spec {
    selector = {
      app = "owncloud"
    }

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    type = "NodePort"
  }

  depends_on = [kubernetes_deployment.app]
}


