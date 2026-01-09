import { spawn } from "child_process";
import path from "path";

export function revertCommand(target: string) {
  const targetRoot = path.resolve(target);
  const args = process.argv.slice(process.argv.indexOf("--") + 1);

  const bin = process.platform === "win32"
    ? "node_modules/.bin/ruler.cmd"
    : "node_modules/.bin/ruler";

  const proc = spawn(bin, ["revert", ...args], {
    cwd: targetRoot,
    stdio: "inherit"
  });

  proc.on("exit", code => process.exit(code ?? 0));
}