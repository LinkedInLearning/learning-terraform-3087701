module "dev" {
    source = "../../modules/blog"

    environment = {
        name            = "dev"
        network_prefix  = "10.1"
    }

    min_size = 1
    max_size = 1
}