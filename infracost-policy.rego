package infracost # your policy files must be under the "infracost" package

# This example shows you how you can create a policy that will fail if the infracost `diffTotalMonthlyCost`
# value is greater than 100 dollars.
deny[out] {
	# maxDiff defines the threshold that you require the cost estimate to be below.
	maxDiff = 100.0

	# msg defines the output that will be shown in PR comments under the Policy Checks/Failures section.
	msg := sprintf(
		"Total monthly cost diff must be less than $%.2f (actual diff is $%.2f)",
		[maxDiff, to_number(input.diffTotalMonthlyCost)],
	)

	# out defines the output for this policy. This output must be formatted with a `msg` and `failed` property.
  	out := {
    	# the msg you want to display in your PR comment
    	"msg": msg,
        # a boolean value that determines if this policy has failed.
        # In this case if the Infracost breakdown output diffTotalMonthlyCost is greater that $10.
    	"failed": to_number(input.diffTotalMonthlyCost) >= maxDiff
  	}
}

# This example shows you how you can create a policy that will fail if your aws instance hourly 
# costs are above $2.0.
deny[out] {
    # find the aws instance resources that are contained in the infracost output.
    # See the "Input" section to the right for more info.
	r := input.projects[_].breakdown.resources[_]
	startswith(r.name, "aws_instance.")

    # maxHourlyCost is the cost threshold that you don't want your aws instance hourly cost to exceed.
	maxHourlyCost := 2.0
	
    # msg defines the output that will be shown in PR comments under the Policy Checks/Failures section.
	msg := sprintf(
		"AWS instances must cost less than $%.2f\\hr (%s costs $%.2f\\hr).",
		[maxHourlyCost, r.name, to_number(r.hourlyCost)],
	)
    
    # out defines the output for this policy. This output must be formatted with a `msg` and `failed` property.
  	out := {
    	# the msg you want to display in your PR comment
    	"msg": msg,
        # a boolean value that determines if this policy has failed.
        # In this case if the the aws instance hourly cost shown in the infracost breakdown output is more than $2.0.
    	"failed": to_number(r.hourlyCost) > maxHourlyCost
  	}
}

# This example shows you how you can create a policy that will fail if your aws instance IOPs 
# costs are above the base hourly cost of the instance.
deny[out] {
    # find the aws instance resources that are contained in the infracost output.
    # See the "Input" section to the right for more info.
	r := input.projects[_].breakdown.resources[_]
	startswith(r.name, "aws_instance.")

	# baseHourlyCost reflects the hourly cost for the aws instance resource.
	baseHourlyCost := to_number(r.costComponents[_].hourlyCost)

	# find the provisioned IOPs for the aws instance resource by filtering
    # the costComponents of the resource based on their name.
	sr_cc := r.subresources[_].costComponents[_]
	sr_cc.name == "Provisioned IOPS"
	iopsHourlyCost := to_number(sr_cc.hourlyCost)
    
    # msg defines the output that will be shown in PR comments under the Policy Checks/Failures section.
	msg := sprintf(
		"AWS instance IOPS must cost less than compute usage (%s IOPS $%.2f\\hr, usage $%.2f\\hr).",
		[r.name, iopsHourlyCost, baseHourlyCost],
	)
    	
    # out defines the output for this policy. This output must be formatted with a `msg` and `failed` property.
  	out := {
    	# the msg you want to display in your PR comment
    	"msg": msg,
        # a boolean value that determines if this policy has failed.
        # In this case if the the aws instance iops cost shown in the infracost breakdown output is more than instance hourly cost.
    	"failed": 	iopsHourlyCost > baseHourlyCost
  	}
}