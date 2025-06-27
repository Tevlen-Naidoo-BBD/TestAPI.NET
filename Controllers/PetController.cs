using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PetStoreAPI.Data;
using PetStoreAPI.Models;
using PetStoreAPI.Dtos;

namespace PetStoreAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PetController : ControllerBase
    {
        private readonly PetStoreContext _context;
        public PetController(PetStoreContext context)
        {
            _context = context;
        }

        // POST: api/pet
        [HttpPost]
        public async Task<IActionResult> AddPet([FromBody] Pet pet)
        {
            await _context.Database.ExecuteSqlRawAsync(
                "CALL add_pet({0}, {1}, {2}, {3})",
                pet.PetName, pet.PetStatus, pet.PetStore, pet.PetImage);
            return Ok();
        }

        // PUT: api/pet/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdatePet(int id, [FromBody] Pet pet)
        {
            await _context.Database.ExecuteSqlRawAsync(
                "CALL update_pet({0}, {1}, {2}, {3}, {4}, {5})",
                id, pet.PetName, pet.PetStatus, pet.PetStore, pet.PetImage, pet.RemovedAt);
            return Ok();
        }

        // PATCH: api/pet/{id}
        [HttpPatch("{id}")]
        public async Task<IActionResult> PartialUpdatePet(int id, [FromBody] Pet pet)
        {
            await _context.Database.ExecuteSqlRawAsync(
                "CALL update_pet({0}, {1}, {2}, {3}, {4}, {5})",
                id, pet.PetName, pet.PetStatus, pet.PetStore, pet.PetImage, pet.RemovedAt);
            return Ok();
        }

        // GET: api/pet/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<PetDto>> GetPetById(int id)
        {
            var pets = await _context.Pets
                .FromSqlRaw("SELECT pet_id, pet_name, pet_status, pet_store FROM find_pet({0})", id)
                .ToListAsync();
            if (pets.Count == 0) return NotFound();
            var pet = pets[0];
            var dto = new PetDto
            {
                PetId = pet.PetId,
                PetName = pet.PetName,
                PetStatus = pet.PetStatus.ToString(),
                PetStore = pet.PetStore?.ToString()
            };
            return Ok(dto);
        }

        // GET: api/pet?status={statusId}
        [HttpGet]
        public async Task<ActionResult<IEnumerable<PetDto>>> GetPetsByStatus([FromQuery] int status)
        {
            var pets = await _context.Pets
                .FromSqlRaw("SELECT pet_id, pet_name, pet_status, pet_store FROM find_pets_by_status({0})", status)
                .ToListAsync();
            var dtos = pets.Select(p => new PetDto
            {
                PetId = p.PetId,
                PetName = p.PetName,
                PetStatus = p.PetStatus.ToString(),
                PetStore = p.PetStore?.ToString()
            });
            return Ok(dtos);
        }

        // POST: api/pet/{id}/image
        [HttpPost("{id}/image")]
        public async Task<IActionResult> UploadPetImage(int id, [FromBody] byte[] image)
        {
            await _context.Database.ExecuteSqlRawAsync(
                "CALL upload_pet_image({0}, {1})",
                id, image);
            return Ok();
        }

        // GET: api/pet/aggregate/status
        [HttpGet("aggregate/status")]
        public async Task<IActionResult> GetPetStatusAggregate()
        {
            var result = await _context.Set<PetStatusAggregateDto>()
                .FromSqlRaw("SELECT pet_status_name, count FROM pet_status_aggregate()")
                .ToListAsync();
            return Ok(result);
        }
    }
} 