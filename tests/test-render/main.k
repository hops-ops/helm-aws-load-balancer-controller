import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.k8s.apimachinery.pkg.apis.meta.v1 as metav1

# ==============================================================================
# Unit tests for AWSLoadBalancerController XRD
#
# Philosophy: Test YOUR API, not the provider's API.
# - render/validate already checks provider schema correctness
# - Tests should verify XRD spec fields produce expected behavior
# ==============================================================================

_items = [
    # ==========================================================================
    # Test 1: Minimal input renders Helm release with clusterName
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "minimal-renders-helm-release"
        spec = {
            compositionPath = "apis/awsloadbalancercontrollers/composition.yaml"
            xrdPath = "apis/awsloadbalancercontrollers/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "helm.hops.ops.com.ai/v1alpha1"
                kind = "AWSLoadBalancerController"
                metadata.name = "test-alb"
                spec = {
                    clusterName = "test-cluster"
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "test-alb"
                    spec.forProvider.values.clusterName = "test-cluster"
                }
            ]
        }
    }

    # ==========================================================================
    # Test 2: Custom labels are applied and merged with defaults
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "custom-labels-merged-with-defaults"
        spec = {
            compositionPath = "apis/awsloadbalancercontrollers/composition.yaml"
            xrdPath = "apis/awsloadbalancercontrollers/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "helm.hops.ops.com.ai/v1alpha1"
                kind = "AWSLoadBalancerController"
                metadata.name = "labeled-alb"
                spec = {
                    clusterName = "test-cluster"
                    labels = {
                        team = "platform"
                        environment = "staging"
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata = {
                        name = "labeled-alb"
                        labels = {
                            "hops.ops.com.ai/managed" = "true"
                            "hops.ops.com.ai/awsloadbalancercontroller" = "labeled-alb"
                            team = "platform"
                            environment = "staging"
                        }
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 3: overrideAllValues replaces defaults
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "override-all-values"
        spec = {
            compositionPath = "apis/awsloadbalancercontrollers/composition.yaml"
            xrdPath = "apis/awsloadbalancercontrollers/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "helm.hops.ops.com.ai/v1alpha1"
                kind = "AWSLoadBalancerController"
                metadata.name = "override-test"
                spec = {
                    clusterName = "my-cluster"
                    overrideAllValues = {
                        clusterName = "my-cluster"
                        fullnameOverride = "custom-alb"
                        replicaCount = 3
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "override-test"
                    spec.forProvider.values = {
                        clusterName = "my-cluster"
                        fullnameOverride = "custom-alb"
                        replicaCount = 3
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 4: Default namespace is kube-system
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "default-namespace-kube-system"
        spec = {
            compositionPath = "apis/awsloadbalancercontrollers/composition.yaml"
            xrdPath = "apis/awsloadbalancercontrollers/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "helm.hops.ops.com.ai/v1alpha1"
                kind = "AWSLoadBalancerController"
                metadata.name = "ns-test"
                spec = {
                    clusterName = "test-cluster"
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "ns-test"
                    spec.forProvider.namespace = "kube-system"
                }
            ]
        }
    }
]

items = _items
