{pkgs, ...}: {
  enable = true;

  publicKeys = [
    {source = ../../.keys/gpg-0xAAB53317F0BECC9B-2025-05-08.asc;}
  ];
}
