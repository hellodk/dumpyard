resource "azurerm_resource_group" "example" {
  # ...

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "example" {
  # ...

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}

resource "aws_instance" "example1" {
  # ...

  tags = {
    # Initial value for Name is overridden by our automatic scheduled
    # re-tagging process; changes to this are ignored by ignore_changes
    # below.
    Name = "placeholder"
  }

  lifecycle {
    ignore_changes = [
      tags["Name"],
    ]
  }
}