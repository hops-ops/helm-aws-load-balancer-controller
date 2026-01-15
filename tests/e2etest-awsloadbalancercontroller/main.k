import datetime
import math
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.k8s.apimachinery.pkg.apis.meta.v1 as metav1

# ==============================================================================
# E2E Test for AWSLoadBalancerController XRD (Kubernetes-only)
#
# This test uses the Helm provider with ProviderConfig which uses
# injected identity (no credentials needed - runs in-cluster).
# ==============================================================================

# Generate unique name using timestamp to avoid CI conflicts
_now = str(int(math.floor(datetime.ticks())))
_test_name = "e2e-alb-" + _now

_items = [
    metav1alpha1.E2ETest {
        metadata.name = "awsloadbalancercontroller-helm"
        spec = {
            crossplane = {
                version = "2.2.0"
                autoUpgrade.channel = "None"
            }
            defaultConditions = ["Ready"]
            skipDelete = False
            timeoutSeconds = 600

            # Helm ProviderConfig - uses in-cluster identity
            extraResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "ProviderConfig"
                    metadata = {
                        name = "default"
                        namespace = "default"
                    }
                    spec = {
                        credentials = {
                            source = "InjectedIdentity"
                        }
                    }
                }
            ]

            # The XR to test
            manifests = [
                {
                    apiVersion = "helm.aws.hops.ops.com.ai/v1alpha1"
                    kind = "AWSLoadBalancerController"
                    metadata = {
                        name = _test_name
                        namespace = "default"
                    }
                    spec = {
                        clusterName = _test_name
                        labels = {
                            "hops.ops.com.ai/e2etest" = "true"
                            "hops.ops.com.ai/test-run" = _now
                        }
                        providerConfigRef = {
                            name = "default"
                            kind = "ProviderConfig"
                        }
                    }
                }
            ]
        }
    }
]

items = _items
