resource "genesyscloud_integration_action" "action" {
    name           = var.action_name
    category       = var.action_category
    integration_id = var.integration_id
    secure         = var.secure_data_action
    
    contract_input  = jsonencode({
        "$schema" = "http://json-schema.org/draft-04/schema#",
        "additionalProperties" = true,
        "description" = "A phone number-based request.",
        "properties" = {
            "AccountId" = {
                "description" = "Account Id to which the opportunity is related",
                "type" = "string"
            }
        },
        "required" = [
            "AccountId"
        ],
        "type" = "object"
    })
    contract_output = jsonencode({
        "additionalProperties" = true,
        "properties" = {
            "Owners" = {
                "items" = {
                    "title" = "Email",
                    "type" = "string"
                },
                "type" = "array"
            }
        },
        "type" = "object"
    })
    
    config_request {
        request_template     = "$${input.rawRequest}"
        request_type         = "GET"
        request_url_template = "/services/data/v54.0/query/?q=$esc.url(\"SELECT Owner.Id, Owner.Email, Id FROM Opportunity WHERE Account.Id = '$${input.AccountId}'\")"
        headers = {
			Content-Type = "application/json"
			UserAgent = "PureCloudIntegrations/1.0"
		}
    }

    config_response {
        success_template = "{\"Owners\": $${Email}}"
        translation_map = { 
			Email = "$.records[*].Owner.Email"
		}
               
    }
}