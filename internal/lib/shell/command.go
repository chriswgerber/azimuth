package shell

import "io"

type Terminal interface {
	Exec(cmd *Command)
}

type Command struct {
	Executable string
	Flags      []string
	Result
}

type Result struct {
	Stdout   io.Reader
	Stderr   io.Reader
	ExitCode int
	Error    error
}

type Zsh struct {
}

func New() *Zsh {
	return &Zsh{}
}

func (z *Zsh) Exec(cmd *Command) {

}
