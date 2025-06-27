namespace PetStoreAPI.Dtos
{
    public class PetDto
    {
        public int PetId { get; set; }
        public string PetName { get; set; } = default!;
        public string PetStatus { get; set; } = default!;
        public string? PetStore { get; set; }
    }
} 