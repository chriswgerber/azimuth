// Azimuth cmd
package main

import (
	"log"

	"github.com/chriswgerber/azimuth/internal/lib/azimuth"
)

func main() {
	log.SetFlags(0)
	log.Println("Hello, World!")
	cmd := azimuth.NewBrew()

	_ = cmd.BundleInstall()
}
