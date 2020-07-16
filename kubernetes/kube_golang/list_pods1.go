package main

import (
	"flag"
	"fmt"
	"path/filepath"

	//	"k8s.io/apimachinery/pkg/api/errors"

	//	"k8s.io/client-go/kubernetes"
	//	"k8s.io/client-go/tools/clientcmd"
	//	"k8s.io/client-go/util/homedir"
	"k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
	"k8s.io/client-go/util/homedir"
)

func main() {
	// var kubeconfig *string
	// uses the current context in kubeconfig
	/*	config, _ := clientcmd.BuildConfigFromFlags("", "/home/vagrant/.kube")
		// creates the clientset
		clientset, _ := kubernetes.NewForConfig(config)*/
	// access the API to list pods

	var kubeconfig *string
	if home := homedir.HomeDir(); home != "" {
		kubeconfig = flag.String("kubeconfig", filepath.Join(home, ".kube", "config"), "(optional) absolute path to the kubeconfig file")
	} else {
		kubeconfig = flag.String("kubeconfig", "", "absolute path to the kubeconfig file")
	}
	flag.Parse()

	config, err := clientcmd.BuildConfigFromFlags("", *kubeconfig)
	if err != nil {
		panic(err)
	}
	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		panic(err)
	}

	pods, _ := clientset.CoreV1().Pods("kube-system").List(v1.ListOptions{})
	// pods, _ := clientset.CoreV1().Pods("").List(v1.ListOptions{})
	fmt.Printf("There are %d pods in the cluster\n", len(pods.Items))
	fmt.Println(pods.Items)
}
