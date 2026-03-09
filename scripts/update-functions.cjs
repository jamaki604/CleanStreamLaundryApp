const { execSync } = require("child_process");

try {
  console.log("Fetching function list...");

  const output = execSync(
    "npx supabase functions list --output json",
    { encoding: "utf-8" }
  );

  const functions = JSON.parse(output);

  if (!functions.length) {
    console.log("No functions found.");
    process.exit(0);
  }

  for (const fn of functions) {
    console.log(`Downloading ${fn.name}...`);
    execSync(`npx supabase functions download ${fn.slug}`, {
      stdio: "inherit",
    });
  }

  console.log("All functions updated successfully.");
} catch (err) {
  console.error("Error updating functions:", err.message);
  process.exit(1);
}