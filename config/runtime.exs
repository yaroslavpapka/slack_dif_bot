import Config

if Mix.env() == :dev do
  DotenvParser.load_file(".env")
end
