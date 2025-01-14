# TFG
Este repositorio contiene todo el código empleado para realizar mi trabajo de fin de grado titulado "Diseño e implementación de medidas y políticas de seguridad para un despliegue automatizado y seguro en la nube".

El código que se proporciona sirve para desplegar recursos y políticas en Azure a través de Terraform y es fácilmente escalable.

El archivo "policies.tf" es donde se encuentran todas las políticas de seguridad desplegadas. En los otros tres archivos ("FrontResources.tf","BackResources.tf", "StorageResources.tf") se encuentra el codigo necesario para el despliegue de la arquitectura divida en las tres capas.

En el archivo "variables.tf" es donde defines el subscription_id y el resource_group_name como una variable y para poder referenciarlo en "policies.tf". 

Lo último que hay que hacer es crearse un archivo llamado "terraform.tfvars" que contenga los valores de las dos variables.
