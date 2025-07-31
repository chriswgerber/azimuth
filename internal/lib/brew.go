package azimuth

import (
	"errors"
	"fmt"
	"os"

	"github.com/chriswgerber/azimuth/internal/lib/shell"
)

const (
	BrewfileEnvName = "BREW_FILE"
)

func getBrewfilePath() string {
	return os.Getenv(BrewfileEnvName)
}

// NoBrewfileError is returned when a command is attempt to be executed that requires the
// Brewfile, but it can't be located from the environmental variable.
type NoBrewfileError struct {
	Reason string
}

func (m *NoBrewfileError) Error() string {
	return fmt.Sprintf("Unable to find or read brewfile: %s", m.Reason)
}

type Brew struct {
	shell shell.Terminal
}

func NewBrew() *Brew {
	return &Brew{shell.New()}
}

func (b *Brew) BundleInstall() *shell.Result {
	result := &shell.Result{}
	brewfile := getBrewfilePath()

	if brewfile == "" {
		result.Error = &NoBrewfileError{Reason: fmt.Sprintf("Env var %s not set", BrewfileEnvName)}
		return result
	}

	if _, err := os.Stat(brewfile); err == nil {
		// path/to/whatever exists

	} else if errors.Is(err, os.ErrNotExist) {
		// path/to/whatever does *not* exist
	} else {
		// Schrodinger: file may or may not exist. See err for details.
		// Therefore, do *NOT* use !os.IsNotExist(err) to test for file existence
	}

}
