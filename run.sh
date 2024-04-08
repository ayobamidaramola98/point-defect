#!/bin/bash

# Initialize an array to store selected atom IDs
selected_atom_ids=()

# Loop to select up to 1000 random atom IDs corresponding to atom type 1
while IFS= read -r line && [[ ${#selected_atom_ids[@]} -lt 500 ]]; do
    atom_id=$(echo "$line" | awk '$2 == 1 {print $1; exit}')
    if [ -n "$atom_id" ]; then
        selected_atom_ids+=("$atom_id")
    fi
done < ASS.txt

# Output file name
output_file="simulation_results.txt"

# Run the simulation for each selected atom ID
for atom_id in "${selected_atom_ids[@]}"; do
    # Output selected atom ID and its corresponding atom type to the output file
    echo -n "$atom_id " >> "$output_file"
    atom_type=$(awk -v id="$atom_id" '$1 == id {print $2; exit}' ASS.txt)
    echo -n "$atom_type " >> "$output_file"

    # Replace the hardcoded atom ID in vac.in with the selected atom ID
    sed -i "s/group           deleted id .*/group           deleted id $atom_id/" vac.in

    # Run LAMMPS simulation for the selected atom ID and capture the Vacancy formation energy
    echo "Running simulation with atom ID $atom_id"
    /usr/bin/mpirun -np 4 lmp_mpi < vac.in | awk '/Vacancy formation energy/ {print $NF}' >> "$output_file"
done

echo "All simulations complete."

