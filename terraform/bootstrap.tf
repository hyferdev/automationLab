# /terraform/bootstrap.tf
# Creates the S3 bucket and objects for Palo Alto bootstrapping.

resource "aws_s3_bucket" "bootstrap_bucket" {
  bucket = lower("${var.project_name}-${var.environment}-pa-bootstrap")

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-${var.environment}-pa-bootstrap-bucket"
  })
}

resource "aws_s3_bucket_public_access_block" "bootstrap_bucket_pab" {
  bucket = aws_s3_bucket.bootstrap_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --- Bootstrap Files ---
resource "aws_s3_object" "init_cfg" {
  bucket  = aws_s3_bucket.bootstrap_bucket.id
  key     = "config/init-cfg.txt"
  content = <<-EOT
    type=dhcp-client
    op-command-modes=jumbo-frame
  EOT
}

resource "aws_s3_object" "bootstrap_xml" {
  bucket  = aws_s3_bucket.bootstrap_bucket.id
  key     = "config/bootstrap.xml"
  content = <<-EOT
    <?xml version="1.0"?>
    <config version="11.1.0" urldb="paloaltonetworks">
      <devices>
        <entry name="localhost.localdomain">
          <network>
            <interface>
              <!-- Egress Interface (out to Internet) -->
              <ethernet>
                <entry name="ethernet1/1">
                  <layer3>
                    <dhcp-client>
                      <create-default-route>no</create-default-route>
                    </dhcp-client>
                  </layer3>
                </entry>
              </ethernet>
              <!-- Trust Interface (for TGW/GENEVE traffic) -->
              <ethernet>
                <entry name="ethernet1/2">
                  <layer3>
                    <dhcp-client>
                      <create-default-route>no</create-default-route>
                    </dhcp-client>
                  </layer3>
                </entry>
              </ethernet>
            </interface>
            <!-- Virtual Router -->
            <virtual-router>
              <entry name="default">
                <interface>
                  <member>ethernet1/1</member>
                  <member>ethernet1/2</member>
                </interface>
                <!-- Default route to the internet via the Egress interface -->
                <routing-table>
                  <ip>
                    <static-route>
                      <entry name="default-route">
                        <path-monitor>
                          <enable>no</enable>
                        </path-monitor>
                        <nexthop>
                          <ip-address>10.0.9.1</ip-address> <!-- IMPORTANT: Replace with the router IP of your egress_subnet -->
                        </nexthop>
                        <destination>0.0.0.0/0</destination>
                        <interface>ethernet1/1</interface>
                      </entry>
                    </static-route>
                  </ip>
                </routing-table>
              </entry>
            </virtual-router>
            <!-- Security Zones -->
            <zone>
              <entry name="UNTRUST">
                <network>
                  <layer3>
                    <member>ethernet1/1</member>
                  </layer3>
                </network>
              </entry>
              <entry name="TRUST">
                <network>
                  <layer3>
                    <!-- Both the physical interface and the tunnel will be in the TRUST zone -->
                    <member>ethernet1/2</member>
                    <member>tunnel.1</member>
                  </layer3>
                </network>
              </entry>
            </zone>
            <!-- GENEVE Tunnel Configuration -->
            <tunnel>
              <geneve>
                <entry name="tunnel.1">
                  <source-interface>ethernet1/2</source-interface>
                  <source-address>
                    <ip>
                      <entry name="10.0.3.5/24"/> <!-- Placeholder, the firewall gets its IP via DHCP -->
                    </ip>
                  </source-address>
                </entry>
              </geneve>
            </tunnel>
          </network>
          <vsys>
            <entry name="vsys1">
              <rulebase>
                <!-- Security Policies -->
                <security>
                  <rules>
                    <!-- Policy for Egress (Spoke VPC to Internet) traffic -->
                    <entry name="Spoke-to-Internet">
                      <to>
                        <member>UNTRUST</member>
                      </to>
                      <from>
                        <member>TRUST</member>
                      </from>
                      <source>
                        <member>any</member>
                      </source>
                      <destination>
                        <member>any</member>
                      </destination>
                      <source-user>
                        <member>any</member>
                      </source-user>
                      <category>
                        <member>any</member>
                      </category>
                      <application>
                        <member>any</member>
                      </application>
                      <service>
                        <member>application-default</member>
                      </service>
                      <source-hip>
                        <member>any</member>
                      </source-hip>
                      <destination-hip>
                        <member>any</member>
                      </destination-hip>
                      <action>allow</action>
                      <log-start>yes</log-start>
                      <log-end>yes</log-end>
                      <!-- This enables Source NAT (SNAT) -->
                      <source-translation>
                        <dynamic-ip-and-port>
                          <interface-address>
                            <interface>ethernet1/1</interface>
                          </interface-address>
                        </dynamic-ip-and-port>
                      </source-translation>
                    </entry>
                    <!-- Policy for Inter-VPC (Spoke to Spoke) traffic -->
                    <entry name="Spoke-to-Spoke">
                      <to>
                        <member>TRUST</member>
                      </to>
                      <from>
                        <member>TRUST</member>
                      </from>
                      <source>
                        <member>any</member>
                      </source>
                      <destination>
                        <member>any</member>
                      </destination>
                      <source-user>
                        <member>any</member>
                      </source-user>
                      <category>
                        <member>any</member>
                      </category>
                      <application>
                        <member>any</member>
                      </application>
                      <service>
                        <member>application-default</member>
                      </service>
                      <action>allow</action>
                      <log-start>yes</log-start>
                      <log-end>yes</log-end>
                      <!-- Note: No Source NAT for internal traffic -->
                    </entry>
                  </rules>
                </security>
              </rulebase>
            </entry>
          </vsys>
        </entry>
      </devices>
    </config>
  EOT
}

