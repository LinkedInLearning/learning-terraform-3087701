module "qa" {
    source = "../../modules/blog"

    environment {
        name            = "qa"
        network_prefix  = "10.2"
    }

    min_size = 1
    max_size = 1
}