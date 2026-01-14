import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.k8s.apimachinery.pkg.apis.meta.v1 as metav1

# ==============================================================================
# E2E Test for AWSLoadBalancerController
#
# This test requires:
# - A Kubernetes cluster with Helm provider configured
# - A ProviderConfig named after the cluster
#
# Note: This is a Helm-only XRD, so E2E testing requires an actual cluster.
# The test validates the Helm release gets created and becomes Ready.
# ==============================================================================

_testName = "e2e-alb-controller"

_items = [
    metav1alpha1.E2ETest {
        metadata.name = "awsloadbalancercontroller-e2e"
        spec = {
            crossplane.autoUpgrade.channel = "Rapid"
            defaultConditions = ["Ready"]
            skipDelete = False
            timeoutSeconds = 600

            # Helm ProviderConfig - uses in-cluster identity
            # Must use helm.m.crossplane.io to match the Release API
            extraResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "ProviderConfig"
                    metadata.name = "default"
                    spec.credentials.source = "InjectedIdentity"
                }
            ]

            # The XR to test
            manifests = [
                {
                    apiVersion = "helm.hops.ops.com.ai/v1alpha1"
                    kind = "AWSLoadBalancerController"
                    metadata = {
                        name = _testName
                        namespace = "default"
                    }
                    spec = {
                        clusterName = "e2e-test-cluster"
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
