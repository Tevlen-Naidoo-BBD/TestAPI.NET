namespace PetStoreAPI.Dtos
{
    public class PetDetailsDto
    {
        public int PetId { get; set; }
        public string PetName { get; set; } = default!;
        public string? PetStore { get; set; }
        public string PetStatus { get; set; } = default!;
    }
} 