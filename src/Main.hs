module Main where

import PandocFilterGraphviz

import Text.Pandoc
import Text.Pandoc.JSON

main :: IO ()
main =
    toJSONFilter graphviz
