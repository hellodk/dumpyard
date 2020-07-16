package main

import (
    "flag"
    "fmt"
    "path/filepath"

    metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
    "k8s.io/client-go/tools/clientcmd"
    "k8s.io/client-go/util/homedir"
    metrics "k8s.io/metrics/pkg/client/clientset/versioned"
)

func main() {
    /*    var kubeconfig, master string //empty, assuming inClusterConfig
          config, err := clientcmd.BuildConfigFromFlags(master, kubeconfig)
          if err != nil {
              fmt.Println(err)
              panic(err)
          }*/
    fmt.Println("Inside main function")
    var kubeconfig *string
    if home := homedir.HomeDir(); home != "" {
        kubeconfig = flag.String("kubeconfig", filepath.Join(home, ".kube", "config"), "(optional) absolute path to the kubeconfig file")
    } else {
        kubeconfig = flag.String("kubeconfig", "", "absolute path to the kubeconfig file")
    }
    flag.Parse()
    fmt.Println("After parse")
    config, err := clientcmd.BuildConfigFromFlags("", *kubeconfig)
    if err != nil {
        panic(err)
    }
    fmt.Println("The configuration is done ", config)
    mc, err := metrics.NewForConfig(config)
    if err != nil {
        fmt.Println("Error", err)
        panic(err)
    }

    podMetrics, err := mc.MetricsV1beta1().PodMetricses(metav1.NamespaceAll).List(metav1.ListOptions{})
    if err != nil {
        fmt.Println("Error:", err)
        return
    }
    fmt.Println("podMetric data received")
    for _, podMetric := range podMetrics.Items {
        podContainers := podMetric.Containers
        for _, container := range podContainers {
            cpuQuantity, ok := container.Usage.Cpu().AsInt64()
            memQuantity, ok := container.Usage.Memory().AsInt64()
            if !ok {
                return
            }
            msg := fmt.Sprintf("Container Name: %s \n CPU usage: %d \n Memory usage: %d", container.Name, cpuQuantity, memQuantity)
            fmt.Println(msg)
        }

    }
}
