using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MasterPlanterApi.Data;
using MasterPlanterApi.Models;

[ApiController]
[Route("[controller]")]
public class PlantsController : ControllerBase
{
    private readonly PlantContext _context;

    public PlantsController(PlantContext context)
    {
        _context = context;
    }

    // GET /plants
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Plant>>> GetPlants()
    {
        return await _context.Plants.ToListAsync();
    }

    // GET /plants/5
    [HttpGet("{id}")]
    public async Task<ActionResult<Plant>> GetPlant(string id)
    {
        var plant = await _context.Plants.FindAsync(id);
        if (plant == null) return NotFound();
        return plant;
    }

    // POST /plants
    [HttpPost]
    public async Task<ActionResult<Plant>> PostPlant(Plant plant)
    {
        _context.Plants.Add(plant);
        await _context.SaveChangesAsync();
        return CreatedAtAction(nameof(GetPlant), new { id = plant.PlantId }, plant);
    }

    // PUT /plants/5
    [HttpPut("{id}")]
    public async Task<IActionResult> PutPlant(string id, Plant plant)
    {
        if (id != plant.PlantId) return BadRequest();

        var exists = _context.Plants.Any(e => e.PlantId == id);

		if (!exists)
		{
			// La pianta non esiste, quindi la aggiungiamo
			_context.Plants.Add(plant);
		}
		else
		{
			// La pianta esiste, aggiorniamo lo stato
			_context.Entry(plant).State = EntityState.Modified;
		}

		try
		{
			await _context.SaveChangesAsync();
		}
		catch (DbUpdateConcurrencyException)
		{
			if (!_context.Plants.Any(e => e.PlantId == id)) return NotFound();
			else throw;
		}

		return NoContent();
    }

    // DELETE /plants/5
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeletePlant(string id)
    {
        var plant = await _context.Plants.FindAsync(id);
        if (plant == null) return NotFound();

        _context.Plants.Remove(plant);
        await _context.SaveChangesAsync();

        return NoContent();
    }
	
	// PUT /update-username
	[HttpPut("update-username")]
	public async Task<IActionResult> UpdateUsername([FromBody] UsernameChangeRequest request)
	{
		if (string.IsNullOrWhiteSpace(request.OldUsername) || string.IsNullOrWhiteSpace(request.NewUsername))
			return BadRequest("Usernames cannot be empty.");

		// Trova tutte le piante dell'utente
		var plants = await _context.Plants
			.Where(p => p.Username == request.OldUsername)
			.ToListAsync();

		if (!plants.Any())
			return NotFound("No plants found for this username.");

		// Aggiorna tutte le righe in memoria
		plants.ForEach(p => p.Username = request.NewUsername);

		await _context.SaveChangesAsync();

		return Ok($"{plants.Count} plants updated.");
	}

	public class UsernameChangeRequest
	{
		public string OldUsername { get; set; }
		public string NewUsername { get; set; }
	}

}
