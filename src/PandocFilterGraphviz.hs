{-# LANGUAGE OverloadedStrings #-}

module PandocFilterGraphviz where

import Crypto.Hash
import Control.Monad (unless)

import Data.ByteString (ByteString)
import Data.Byteable (toBytes)
import qualified Data.ByteString.Char8 as C8
import qualified Data.ByteString.Base16 as B16

import qualified Data.Map.Strict as M
import Data.Text as T
import Data.Text.Encoding as E

import System.FilePath
import System.Directory
import System.Exit
import System.Process (system)

import Text.Pandoc
import Text.Pandoc.JSON

data Renderer = Dot | Neato | Twopi | Circo | FDP | SFDP | Patchwork
instance Show Renderer where
  show Dot = "dot"
  show Neato = "neato"
  show Twopi = "twopi"
  show Circo = "circo"
  show FDP = "fdp"
  show SFDP = "sfdp"
  show Patchwork = "patchwork"

rendererFromString :: Text -> Maybe Renderer
rendererFromString "dot" = Just Dot
rendererFromString "neato" = Just Neato
rendererFromString "twopi" = Just Twopi
rendererFromString "circo" = Just Circo
rendererFromString "fdp" = Just FDP
rendererFromString "sfdp" = Just SFDP
rendererFromString "patchwork" = Just Patchwork
rendererFromString _ = Nothing

(¤) :: Text -> Text -> Text
(¤) = T.append

hexSha3_512 :: ByteString -> ByteString
hexSha3_512 bs = C8.pack $ show (hash bs :: Digest SHA3_512)

sha :: Text -> Text
sha = E.decodeUtf8 . hexSha3_512 . B16.encode . E.encodeUtf8

fileName4Code :: Text -> Text -> Maybe Text -> FilePath
fileName4Code name source ext =
  filename
  where
    dirname = name ¤ "-images"
    shaN = sha source
    barename = shaN ¤ (case ext of
        Just e -> "." ¤ e
        Nothing -> "")
    filename = T.unpack dirname </> T.unpack barename

getCaption :: M.Map Text Text -> (Text,Text)
getCaption m = case M.lookup "caption" m of
  Just cap -> (cap,"fig:")
  Nothing -> ("","")

getFmt :: Maybe Format -> String
getFmt mfmt = case mfmt of
  Just (Format "latex") -> "pdf"
  Just (Format "beamer") -> "pdf"
  Just _ -> "png"
  Nothing -> "png"

renderDot1 :: Maybe Format -> Maybe Renderer -> FilePath -> IO FilePath
renderDot1 mfmt mrndr src = renderDot mfmt rndr src dst >> return dst
  where
    dst = (dropExtension src) <.> (getFmt mfmt)
    rndr = case mrndr of
      Just r -> r
      Nothing -> Dot

renderDot :: Maybe Format -> Renderer -> FilePath -> FilePath -> IO ExitCode
renderDot mfmt rndr src dst =
  system $
    Prelude.unwords [ show rndr
                    , "-T" ++ (getFmt mfmt)
                    , "-o" ++ show dst
                    , show src ]

graphviz :: Maybe Format -> Block -> IO Block
graphviz mfmt cblock@(CodeBlock (id, classes, attrs) content) =
  if "graphviz" `elem` classes then do
    ensureFile dest >> writeFile dest content
    img <- renderDot1 mfmt mrndr dest
    ensureFile img
    return $ Para [Image (id,classes,attrs) [] (img, T.unpack caption)]
  else return cblock
  where
    dest = fileName4Code "graphviz" (T.pack content) (Just "dot")
    ensureFile fp =
      let dir = takeDirectory fp in
      createDirectoryIfMissing True dir >> doesFileExist fp >>=
        \exist ->
          unless exist $ writeFile fp ""
    toTextPairs = Prelude.map (\(f,s) -> (T.pack f,T.pack s))
    m = M.fromList $ toTextPairs $ attrs
    mrndr = case M.lookup "renderer" m of
      Just str -> rendererFromString str
      _ -> Nothing
    (caption, typedef) = getCaption m
graphviz fmt x = return x

